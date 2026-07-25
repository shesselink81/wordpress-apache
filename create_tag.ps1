$version="7.0.2.3"
git tag -a $version -m "Release version $version"
git push origin $version
echo "Tag $version created and pushed to origin."