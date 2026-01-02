# GitHub Setup Instructions

## Step 1: Create a New Repository on GitHub

1. Go to [GitHub.com](https://github.com) and sign in with your account (ubaidullaah)
2. Click the **"+"** icon in the top right corner
3. Select **"New repository"**
4. Fill in the repository details:
   - **Repository name**: `end-to-end-fintech-project` (or any name you prefer)
   - **Description**: "End-to-End Fintech Data Engineering Project with Airflow, Snowflake, and DBT"
   - **Visibility**: Choose Public or Private
   - **DO NOT** initialize with README, .gitignore, or license (we already have these)
5. Click **"Create repository"**

## Step 2: Push Your Code to GitHub

After creating the repository, GitHub will show you commands. Use these commands in your terminal:

### Option A: Using HTTPS (Recommended for beginners)

```bash
# Add the remote repository (replace YOUR_USERNAME and REPO_NAME with your actual values)
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git

# Rename the branch to main (if needed)
git branch -M main

# Push your code
git push -u origin main
```

**Example:**
```bash
git remote add origin https://github.com/ubaidullaah/end-to-end-fintech-project.git
git branch -M main
git push -u origin main
```

**Note:** You'll be prompted for your GitHub username and password. For password, use a **Personal Access Token** (not your GitHub password). See Step 3 below.

### Option B: Using SSH (If you have SSH keys set up)

```bash
git remote add origin git@github.com:YOUR_USERNAME/REPO_NAME.git
git branch -M main
git push -u origin main
```

## Step 3: Create a Personal Access Token (For HTTPS)

If you're using HTTPS, you'll need a Personal Access Token:

1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click **"Generate new token (classic)"**
3. Give it a name (e.g., "End-to-End Project")
4. Select scopes: Check **"repo"** (this gives full control of private repositories)
5. Click **"Generate token"**
6. **Copy the token immediately** (you won't see it again!)
7. When pushing, use this token as your password

## Step 4: Verify Your Push

After pushing, refresh your GitHub repository page. You should see all your files there!

## Troubleshooting

### If you get "remote origin already exists":
```bash
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git
```

### If you need to change the remote URL:
```bash
git remote set-url origin https://github.com/YOUR_USERNAME/REPO_NAME.git
```

### If you get authentication errors:
- Make sure you're using a Personal Access Token (not your password) for HTTPS
- Or set up SSH keys for SSH authentication

### To check your current remote:
```bash
git remote -v
```

