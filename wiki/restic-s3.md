# Restic on versioned S3 - recovery

Recovering a restic repo on a versioned S3 bucket after files were deleted or overwritten
(evil script, bad prune, etc). Old versions only exist until the lifecycle rule expires them - act fast.

Use admin credentials (restic creds should lack `s3:DeleteObjectVersion`). Set up once:

    export AWS_DEFAULT_REGION=eu-north-1
    BUCKET=my-bucket
    PREFIX=                          # repo path inside bucket, if any
    SINCE=2026-10-27T00:00:00        # UTC, just before the damage started
    aws s3api list-object-versions --bucket $BUCKET --prefix "$PREFIX" --output json > versions.json

## Deleted files - remove delete markers

A plain delete only adds a delete marker; removing the marker brings the previous version back.

Prefer only removing markers created after `$SINCE`.
Removing *all* markers also works, but resurrects everything restic ever pruned
(old snapshots, packs, locks, indexes) - recoverable, but messy.

    jq -c --arg since "$SINCE" '
      [.DeleteMarkers[]? | select(.IsLatest and .LastModified >= $since) | {Key, VersionId}]
      | [range(0; length; 1000) as $i | .[$i:$i+1000]][] | {Objects: ., Quiet: true}' versions.json |
    while read -r batch; do
      printf '%s' "$batch" > batch.json   # file://, a 1000-key batch exceeds max arg size
      aws s3api delete-objects --bucket $BUCKET --delete file://batch.json
    done

## Overwritten files - restore the first version

Restic never overwrites a file, so any key with more than one version was tampered with.
The oldest version is the one restic wrote - copy it back on top.

    jq -r '[.Versions[]] | group_by(.Key)[] | select(length > 1)
      | min_by(.LastModified) | select(.IsLatest | not) | [.Key, .VersionId] | @tsv' versions.json |
    while IFS=$'\t' read -r key vid; do
      aws s3api copy-object --bucket $BUCKET --key "$key" --copy-source "$BUCKET/$key?versionId=$vid" > /dev/null
    done

## Bucket deleted

S3 only deletes empty buckets, i.e. every version was already permanently deleted. Not recoverable.

## Verify and restore

    restic unlock            # remove resurrected/stale locks
    restic repair index      # rebuild index if packs and indexes disagree
    restic check --read-data # slow, reads everything
    restic snapshots
    restic restore latest --target ./restore

## Cleanup afterwards

Once a fresh backup is verified, prune as usual. With versioning the pruned/repacked packs
become noncurrent versions and still cost money until the lifecycle rule expires them.

    restic forget --keep-last 1 --prune --max-unused unlimited   # unlimited = no repack, only delete fully unused packs

To reclaim the space immediately, sweep noncurrent versions and then delete markers
(re-list `versions.json` first). Markers must go *after* versions - removing a marker
while older versions exist resurrects the object.

    jq -c '[.Versions[] | select(.IsLatest | not) | {Key, VersionId}]
      | [range(0; length; 1000) as $i | .[$i:$i+1000]][] | {Objects: ., Quiet: true}' versions.json |
    while read -r batch; do
      printf '%s' "$batch" > batch.json
      aws s3api delete-objects --bucket $BUCKET --delete file://batch.json
    done
    # then same loop with: [.DeleteMarkers[]? | {Key, VersionId}]

Check sizes (current vs noncurrent):

    aws s3api list-object-versions --bucket $BUCKET --prefix "$PREFIX" --query '{
      current_bytes:    sum(Versions[?IsLatest==`true`].Size),
      noncurrent_bytes: sum(Versions[?IsLatest==`false`].Size),
      delete_markers:   length(DeleteMarkers || `[]`)}'
