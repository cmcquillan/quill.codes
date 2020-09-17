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

echo "Checking out gh-pages branch into public"
git worktree add -B gh-pages public origin/gh-pages

echo "Removing existing files"
rm -Recurse -Force public/* -Exclude .*

echo "Generating site"
hugo

echo "Changing to public directory"
cd public
git add .
git commit -m "Publishing to gh-pages (publish_to_pages.ps1)"

echo "Pushing to github"
git push

echo "Completed"
cd ..