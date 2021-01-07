# post install stuff goes here
# get git key 
cp /mnt/clones/data/.ssh/github_rsa ~/.ssh 
chmod 600 ~/.ssh/github_rsa
docker run --rm hello-world