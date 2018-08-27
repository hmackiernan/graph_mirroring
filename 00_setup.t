# Setting up Helix and Partner System(s)

# Partner

# Add users to partner system 

## Configure users with passwords and ssh keys, possibly as part of creation

# create groups (Gerrit)
# Add users to groups (Gerrit)

# add projects to partner system
## configure project visibility (public/private) if applicable
## add users to projects with required access levels (via Groups in gerrit, directly via membership in GitLab)

# set up distinct execution contexts for users against partner system
# to run git commands (clone, add/edit/delete, commit, fetch, push, pull)

use P4::test;
use LWP::UserAgent;
use JSON::Parse;

