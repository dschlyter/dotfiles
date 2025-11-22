#!/usr/bin/env python3

# Input: 
# 1: text file with list of <first name> <email> per line (spaces in names NOT supported), empty line indicates new group (people in same group should not gift to each other)
# 2: mail template file, with {name} {email} and {gift_to} placeholders

import os
import random
import sys
from typing import List


def main():
    input_file = sys.argv[1]
    mail_template = sys.argv[2]

    groups = [set()]
    with open(input_file, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                # empty line indicates new group - people in the same group should not gift to each other
                groups.append(set())
            else:
                groups[-1].add(line)

    attempt = 0
    while True:
        attempt += 1
        if attempt > 100:
            print("Failed to generate valid secret santa mapping after 100 tries")
            sys.exit(1)
        
        secret_map = {}
        valid = True
        for group in groups:
            for person in group:
                choices = {p2 for g2 in groups for p2 in g2 if g2 != group and p2 not in secret_map.values()}
                if not choices:
                    valid = False
                    continue
                gift_to = random.choice(list(choices))
                secret_map[person] = gift_to
        if valid:
            break
        print("No valid choices, retrying...")

    print("\n", "Secret Santa assignments:")
    for k, v in secret_map.items():
        print(f"{k} -> {v}")

    for k, v in secret_map.items():
        with open(mail_template, 'r') as f:
            mail_body = f.read()
            name, email = k.split()
            gift_name, gift_email = v.split()
            mail_body = mail_body.replace("{name}", name)
            mail_body = mail_body.replace("{email}", email)
            mail_body = mail_body.replace("{gift_to}", gift_name)

            print("\n", "---", "\n")
            print(mail_body)


if __name__ == '__main__':
    main()
