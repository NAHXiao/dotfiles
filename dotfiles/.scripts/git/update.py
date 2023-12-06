#!/usr/bin/env python
import os
import subprocess

def update_repositories(path="."):
    repositories = [d for d in os.listdir(path) if os.path.isdir(os.path.join(path, d))]
    for repo in repositories:
        repo_path = os.path.join(path, repo)
        if os.path.exists(os.path.join(repo_path, ".git")):
            print(f"Updating repository: {repo}")
            result=True
            try:
                subprocess.run(["git", "-C", repo_path, "fetch", "--all"], check=True)
                subprocess.run(["git", "-C", repo_path, "reset", "--hard", "origin"], check=True)
                subprocess.run(["git", "-C", repo_path, "pull", "origin"],check=True)
            except subprocess.CalledProcessError:
                result=False
            if result:
                print(f"\033[32mRepository {repo} updated\033[0m\n")
            else:
                print(f"\033[31mRepository {repo} update failed\033[0m\n")

if __name__ == "__main__":
    update_repositories()
