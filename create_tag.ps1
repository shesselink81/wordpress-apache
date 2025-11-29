$version="6.9-RC3.1"
git tag -a v$version -m "Release version $version"
git push origin v$version
echo "Tag v$version created and pushed to origin."