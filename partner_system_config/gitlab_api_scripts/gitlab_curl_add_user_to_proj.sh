#!/bin/sh -x

# adds the specified user (by numerical ID) to the specified project (root/<proj>)
# at the hard-coded access level of 30 (developer)
# on the hard-coded gitlab instance named hsm-another-gitlabee.das.perforce.com
# token is also hard-coded

echo $1 # numerical user id
echo $2 # project name


curl --request POST --header "PRIVATE-TOKEN: rsBQufy5Mruj2grS7dFL" --data "user_id=$1&access_level=30" http://hsm-another-gitlabee.das.perforce.com/api/v4/projects/root%2F$2/members
