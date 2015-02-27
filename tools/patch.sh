#!/bin/bash

username=$(swarm user)
eval domain=$(python tools/domain.py)

# build the tmp.sh file
cat > ./tmp.sh <<EOF
#!/bin/bash
export domain=$domain
sed -e "s,my-ghost-blog.com,$domain,g;" -i config.js
EOF

# make it executable
chmod 755 ./tmp.sh
