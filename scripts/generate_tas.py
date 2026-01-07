#!/usr/bin/env python3

import csv
import random
import yaml

INSTRUCTOR = 'pbui'

STUDENTS = []
for student in csv.DictReader(open('data/gradebook.csv')):
    netid = student['SIS Login ID']
    if not netid or len(netid) > 8:
        continue
    STUDENTS.append(netid)

GRADERS = [
    grader['github'] for grader in yaml.safe_load(open('data/staff.yaml'))
    if grader['netid'] != INSTRUCTOR
]

CONFLICTS = {
    grader['github']: grader['conflicts']
    for grader in yaml.safe_load(open('data/staff.yaml'))
    if grader.get('conflicts')
}

HAS_CONFLICTS = True


while HAS_CONFLICTS:
    random.shuffle(STUDENTS)
    random.shuffle(GRADERS)

    GRADERS = GRADERS * (len(STUDENTS) // len(GRADERS) + 1)
    MAPPING = [
        {'student': student, 'grader': ta}
        for student, ta in sorted(zip(STUDENTS, GRADERS))
    ]

    HAS_CONFLICTS = False

    for grader, conflicts in CONFLICTS.items():
        for conflict in conflicts:
            if {'student': conflict, 'grader': grader} in MAPPING:
                HAS_CONFLICTS = True

print(yaml.dump(MAPPING, default_flow_style=False))
