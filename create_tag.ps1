$version="7.0.3.2"
git tag -a $version -m "Release version $version"
git push origin $version
echo "Tag $version created and pushed to origin."