# Manual Deployment Instructions for match-drivers Function

## ⚠️ CRITICAL UPDATE

The package.json has been updated to include `"type": "module"` to support ES6 imports. **You must redeploy the function** for it to work properly.

## Option 1: Deploy via Appwrite Console (Recommended)

### Steps:

1. **Go to Appwrite Console**: https://cloud.appwrite.io/console/project-68ed397e000f277c6936/functions

2. **Click on "match-drivers" function**

3. **Go to "Deployments" tab**

4. **Click "Create deployment"**

5. **Upload the deployment archive**:
   - File location: `functions/match-drivers/deployment.tar.gz` (2.8KB)
   - Updated: December 6, 2025
   
6. **Set deployment settings**:
   - Entrypoint: `src/main.js`
   - Build Commands: `npm install`
   - Activate on completion: ✅ Yes

7. **Click "Deploy"**

8. **Wait for build to complete** (usually 1-2 minutes)

## What Changed

The package.json now includes:
```json
{
  "type": "module",
  ...
}
```

This enables ES6 import statements in main.js:
```javascript
import { Client, Databases, Query } from 'node-appwrite';
```

Without this, the function fails with:
```
SyntaxError: Cannot use import statement outside a module
```

## Option 2: Rebuild the Deployment Archive

If needed, recreate the deployment archive:

```bash
cd functions/match-drivers
rm -f deployment.tar.gz
tar -czf deployment.tar.gz package.json src/
```

## Function Configuration

The function is already configured with:
- **Name**: match-drivers
- **Runtime**: Node.js 18.0
- **Entrypoint**: src/main.js
- **Build Commands**: npm install
- **Timeout**: 15 seconds
- **Execute Permissions**: Any authenticated user
- **Logging**: Enabled

## Testing After Deployment

Once deployed, you can test the function from:

### 1. Appwrite Console
   - Go to function → Execute
   - Use test payload:
   ```json
   {
     "childId": "test",
     "pickupPoint": [71.5249, 34.0151],
     "schoolId": "675129e7002f54e49f0c",
     "gender": "Male"
   }
   ```

### 2. Flutter App
   - Set `_useDemoData = false` in FindDriversController
   - Select a child with valid pickup location
   - Check Find tab - should show real drivers

## Troubleshooting

### Build Fails
- Check that package.json is valid JSON
- Ensure node-appwrite dependency version is correct
- Check build logs in Appwrite Console

### Function Returns Error
- Check function logs in Appwrite Console
- Verify database has driver_services with geo data
- Ensure schools table has valid data

### No Drivers Returned
- Verify child has pickLocation set
- Check if any drivers serve the child's school
- Verify drivers have active status in users table

## Environment Variables

The function uses these Appwrite-provided variables (automatically set):
- `APPWRITE_FUNCTION_API_ENDPOINT`
- `APPWRITE_FUNCTION_PROJECT_ID`  
- `APPWRITE_API_KEY`

No manual environment variables needed!
