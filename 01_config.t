# configure Helix to mirror against Partner System

# in GCONN root, using
# $partner_url = ssh or http style url for the partner system repo
# $helix_repo_name name of repo as it will appear in Helix
# bin/gconn --mirrohooks add $helix_repo_name $partner_url

# capture the 'secret' in $mirror_secret

# in partner system
# add webhook with
# $helix_gconn_url = "https://<gconn_host/mirrohooks"
# hook types commit and tag, if supported by partner system
# suppress SSH cert validation
