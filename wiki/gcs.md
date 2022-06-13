## Size of dir

    gsutil ls -l gs://mybucket/mydir

## Size of multiple dirs

    gsutil ls -lr 'gs://mybucket/mydir/20210102T*'

## Size of entire bucket

May be slow

    gsutil ls -lr gs://mybucket