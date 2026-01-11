# Debugging Authentication Issues

## Problem: Account Created in Firebase Auth but Not in Firestore

### Common Causes:

1. **Firestore Security Rules Not Deployed** ⚠️ MOST COMMON
   - The security rules must be deployed to Firebase
   - Run: `firebase deploy --only firestore:rules`
   - Check Firebase Console → Firestore → Rules tab

2. **Permission Denied Error**
   - Check if user is authenticated when writing to Firestore
   - Verify security rules allow authenticated users to create their own profile

3. **Network/Connection Issues**
   - Check internet connection
   - Verify Firebase project is properly configured

## How to Debug:

### Step 1: Check Logs

The implementation now includes comprehensive logging. Look for these log messages:

**Sign Up Flow:**
```
🟢 [SignUpNotifier] signUp called
🟢 [SignUpNotifier] Input validation passed
🔵 [AuthRepository] SignUp started
🔵 [AuthRepository] Step 1: Creating user in Firebase Auth...
✅ [AuthRepository] Step 1: User created in Firebase Auth. UID: xxx
🔵 [AuthRepository] Step 3: Creating user profile in Firestore...
✅ [AuthRepository] Step 3: User profile saved to Firestore successfully
```

**If you see errors:**
```
❌ [AuthRepository] Step 3: FirebaseException occurred
❌ [AuthRepository] Step 3: Error code: permission-denied
```

### Step 2: Check Firebase Console

1. **Firebase Auth Console:**
   - Go to Firebase Console → Authentication → Users
   - Verify user was created

2. **Firestore Console:**
   - Go to Firebase Console → Firestore Database
   - Check if `users/{uid}` document exists
   - If not, check the Rules tab to see if rules are deployed

3. **Firestore Rules:**
   - Go to Firebase Console → Firestore → Rules
   - Verify rules are deployed (not just saved locally)
   - Test rules using the Rules Playground

### Step 3: Deploy Firestore Rules

If rules are not deployed:

```bash
# Install Firebase CLI if not installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Deploy rules
firebase deploy --only firestore:rules
```

### Step 4: Test Security Rules

In Firebase Console → Firestore → Rules → Rules Playground:

1. Set up test:
   - Location: `users/{userId}`
   - Authenticated: Yes
   - User ID: `test-uid-123`
   - Operation: Write (create)

2. Test data:
```json
{
  "uid": "test-uid-123",
  "email": "test@example.com",
  "username": "testuser",
  "phone": "+1234567890",
  "role": "buyer",
  "isActive": true,
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

3. Click "Run" - should return "Allow"

## Quick Fixes:

### Fix 1: Deploy Firestore Rules

```bash
firebase deploy --only firestore:rules
```

### Fix 2: Temporarily Allow Writes (FOR TESTING ONLY)

**⚠️ WARNING: Only for development/testing!**

Update `firestore.rules` temporarily:

```javascript
match /users/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}
```

Then deploy:
```bash
firebase deploy --only firestore:rules
```

**Remember to restore proper security rules before production!**

### Fix 3: Check Firebase Project Configuration

Verify `firebase_options.dart` has correct project ID:
- Should match your Firebase project ID
- Check `android/app/google-services.json` for Android
- Check Firebase Console project settings

## Expected Log Output (Success):

```
🟢 [SignUpNotifier] signUp called
🟢 [SignUpNotifier] Email: user@example.com, Username: testuser, Role: buyer
🟢 [SignUpNotifier] Previous errors cleared
🟢 [SignUpNotifier] Validating inputs...
✅ [SignUpNotifier] Input validation passed
🟢 [SignUpNotifier] Setting loading state...
🟢 [SignUpNotifier] Calling repository.signUp()...
🔵 [AuthRepository] SignUp started for email: user@example.com
🔵 [AuthRepository] Step 1: Creating user in Firebase Auth...
✅ [AuthRepository] Step 1: User created in Firebase Auth. UID: abc123xyz
ℹ️ [AuthRepository] Step 2: No profile image provided, skipping upload
🔵 [AuthRepository] Step 3: Creating user profile in Firestore...
🔵 [AuthRepository] Step 3: UID: abc123xyz, Email: user@example.com, Username: testuser, Role: buyer
🔵 [AuthRepository] Step 3: User data to save: {uid: abc123xyz, email: user@example.com, ...}
🔵 [AuthRepository] Step 3: Current auth user: abc123xyz
🔵 [AuthRepository] Step 3: Writing to Firestore path: users/abc123xyz
✅ [AuthRepository] Step 3: User profile saved to Firestore successfully
🔵 [AuthRepository] Step 3: Verifying document creation...
✅ [AuthRepository] Step 3: Verified - Document exists in Firestore
✅ [AuthRepository] SignUp completed successfully for UID: abc123xyz
✅ [SignUpNotifier] Repository signUp completed successfully
✅ [SignUpNotifier] Created user: testuser (abc123xyz)
✅ [SignUpNotifier] State updated with success
```

## Expected Log Output (Error):

```
❌ [AuthRepository] Step 3: FirebaseException occurred
❌ [AuthRepository] Step 3: Error code: permission-denied
❌ [AuthRepository] Step 3: Error message: Missing or insufficient permissions.
```

This means **Firestore security rules are blocking the write**.

## Next Steps:

1. **Check logs** in your IDE console or device logs
2. **Deploy Firestore rules** if not deployed
3. **Verify rules** in Firebase Console Rules Playground
4. **Check Firebase project** configuration
5. **Test with a simple write** to verify rules work

---

**If issues persist, share the complete log output from your console.**

