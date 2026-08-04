# Performance Optimization - Excessive Rebuild Fix

## Issue
The application was experiencing excessive rebuilds causing performance issues:
- ModulesView was rebuilding continuously
- ScreenScaffold was rebuilding excessively
- Multiple API calls were being made unnecessarily
- Console logs showed repeated "ModulesView build" and "building screen scaffold" messages

## Root Causes
1. **Inefficient Provider listening**: Using `Provider.of<T>(context)` without `listen: false` caused rebuilds on any provider change
2. **Unnecessary setState() calls**: Multiple setState calls without checking if the widget was mounted or if data actually changed
3. **Poor listener management**: File storage listeners not properly cleaned up

## Solutions Implemented

### 1. ModulesView Optimizations (`lib/src/screens/modules/modules.dart`)

#### Use Selector for Targeted Rebuilds
- Changed from listening to entire `WebPageProvider` to only listening to `loadingStatus` changes
- Used `Selector<WebPageProvider, DataLoadingStatus>` to rebuild only when loading status changes
- Access `list` with `listen: false` to prevent unnecessary rebuilds

**Before:**
```dart
DataLoadingStatus loadingStatus = Provider.of<WebPageProvider>(context).loadingStatus;
List<WebPage>? modules = Provider.of<WebPageProvider>(context).list;
```

**After:**
```dart
return Selector<WebPageProvider, DataLoadingStatus>(
  selector: (_, provider) => provider.loadingStatus,
  builder: (context, loadingStatus, child) {
    List<WebPage>? modules = Provider.of<WebPageProvider>(context, listen: false).list;
    // ...
  }
);
```

#### Optimize loadModules() Method
- Check `mounted` before calling setState
- Remove unnecessary setState call after loading completed pathways
- Let the provider trigger rebuilds through its own notifyListeners

**Before:**
```dart
setState(() {
  // Empty setState causing unnecessary rebuilds
});
```

**After:**
```dart
if(value != null && mounted) {
  thumbnails[moduleid] = value;
  setState(() {
    // Update thumbnails
  });
}
// Removed unnecessary setState at end
```

#### Optimize _fileStorageListener
- Only call setState when data actually changes
- Check mounted state before updating

**Before:**
```dart
void _fileStorageListener() async{
  completedPathways = await EcoUnityStorage(fileStorage).getCompletedPathways();
  setState(() {
    // Always calling setState
  });
}
```

**After:**
```dart
void _fileStorageListener() async{
  List<PathwayStatusItem>? newCompletedPathways = await EcoUnityStorage(fileStorage).getCompletedPathways();
  if(mounted && newCompletedPathways != completedPathways) {
    completedPathways = newCompletedPathways;
    setState(() {
      // Only update when data changes
    });
  }
}
```

### 2. ScreenScaffold Optimizations (`lib/src/widgets/screenscaffold.dart`)

#### Use Selector for User Changes
- Changed from listening to entire `UserProvider` to only listening to `user` changes
- Used `Selector<core.UserProvider, core.User>` to rebuild only when user changes

**Before:**
```dart
core.User user = Provider.of<core.UserProvider>(context).user;
```

**After:**
```dart
return Selector<core.UserProvider, core.User>(
  selector: (_, provider) => provider.user,
  builder: (context, user, child) {
    // Build widget with user
  }
);
```

#### Fix File Storage Listener Management
- Created a named function for the listener for proper cleanup
- Ensure listener is properly removed in dispose

**Before:**
```dart
fileStorage.addListener(() async {
  if(mounted) {
    setState(() {});
  }
});
// Incorrect dispose - creates new anonymous function
fileStorage.removeListener(() {});
```

**After:**
```dart
void _onFileStorageChange() {
  if(mounted) {
    setState(() {});
  }
}

@override
void initState(){
  fileStorage.addListener(_onFileStorageChange);
  super.initState();
}

@override
void dispose(){
  fileStorage.removeListener(_onFileStorageChange);
  super.dispose();
}
```

## Expected Results
- Significantly reduced number of rebuilds
- Fewer unnecessary API calls
- Better app responsiveness
- Reduced console log spam
- Lower memory usage
- Improved battery life on mobile devices

## Testing
To verify the fix:
1. Run the app and navigate to the Modules screen
2. Check console logs - should see far fewer "ModulesView build" messages
3. Monitor API calls - should see fewer redundant calls
4. Test navigation and interactions - should feel more responsive

## Best Practices Going Forward
1. Always use `listen: false` when accessing providers for one-time data reads
2. Use `Selector` or `Consumer` to listen only to specific properties that should trigger rebuilds
3. Always check `mounted` before calling `setState()`
4. Use named functions for listeners to ensure proper cleanup
5. Avoid empty `setState(() {})` calls - they should always have a clear purpose
6. Consider using `const` constructors where possible to prevent unnecessary widget rebuilds
7. Profile the app regularly to catch performance issues early

## Related Files
- `/lib/src/screens/modules/modules.dart`
- `/lib/src/widgets/screenscaffold.dart`

## Date
March 23, 2026
