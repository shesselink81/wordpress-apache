$version="7.1.2.0"
git tag -a $version -m "Release version $version"
git push origin $version
echo "Tag $version created and pushed to origin."