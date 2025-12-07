$version="6.9.0.5"
git tag -a v$version -m "Release version $version"
git push origin v$version
echo "Tag v$version created and pushed to origin."