# Add Custom API Key to Function

## Step 1: Create API Key

1. Go to: https://cloud.appwrite.io/console/project-68ed397e000f277c6936/settings/keys
2. Click **"Create API Key"**
3. Settings:
   - **Name**: `match-drivers-function`
   - **Scopes**: Check these:
     - ✅ `databases.read`
     - ✅ `tables.read` 
     - ✅ `rows.read`
     - ✅ `documents.read` (if available)
   - **Expiration**: Never (or far future)
4. Click **"Create"**
5. **Copy the API key** (starts with `standard_...`)

## Step 2: Add to Function Environment Variables

Once you have the API key, I'll use the MCP tool to add it to the function.

**OR** you can add it manually:
1. Go to: https://cloud.appwrite.io/console/project-68ed397e000f277c6936/functions/match-drivers
2. Click **"Settings"** tab
3. Scroll to **"Environment variables"**
4. Click **"Add variable"**
5. Settings:
   - **Key**: `CUSTOM_API_KEY`
   - **Value**: [paste your API key]
   - **Secret**: ✅ Check this
6. Click **"Create"**

## Step 3: Share the API Key

Once created, share the API key here and I'll add it via MCP tool.
