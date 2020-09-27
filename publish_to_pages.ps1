if ($(git status -s) -ne $null)
{
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
}

echo "Deleting old publication"
rm -Recurse -Force public
# mkdir public
git worktree prune
# rm -Recurse -Force .git/worktrees/public/

# Build Angular Application
pushd assets\apps\fiddle\src\Fiddle.Run.Client
ng build --prod --outputPath=..\..\..\..\..\content\apps\fiddle --baseHref=/apps/fiddle/ --deployUrl=/apps/fiddle/
popd

echo "Checking out gh-pages branch into public"
git worktree add -B gh-pages public origin/gh-pages

echo "Removing existing files"
rm -Recurse -Force public/* -Exclude .*

echo "Generating site"
hugo

echo "Changing to public directory"
pushd public
git add .
git commit -m "Publishing to gh-pages (publish_to_pages.ps1)"

echo "Pushing to github"
git push

echo "Completed"
popd