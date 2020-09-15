if ($(git status -s) -ne $null)
{
    echo "The working directory is dirty. Please commit any pending changes."
    exit 1;
}

echo "Deleting old publication"
rm -Force public
mkdir public
git worktree prune
rm -Force .git/worktrees/public/

echo "Checking out gh-pages branch into public"
git worktree add -B gh-pages public origin/gh-pages

echo "Removing existing files"
rm -Force public/*

echo "Generating site"
hugo

echo "Changing to public directory"
cd public
git add --all
git commit -m "Publishing to gh-pages (publish.sh)"

echo "Pushing to github"
git push --all
