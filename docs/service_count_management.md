# Service Count Management

This document describes how service counts are managed for categories in the application.

## Overview

Each category displays the number of services associated with it. This count is stored in the `serviceCount` field of each category document in Firestore to minimize read operations and improve performance.

## Implementation Details

### Data Structure

- Categories collection: Each document has a `serviceCount` field
- Services collection: Each service has a `categoryId` field referencing its category

### Automatic Updates

The `serviceCount` field is updated using the `update_category_service_counts.js` script, which:
1. Retrieves all categories
2. Counts services for each category using Firestore queries
3. Updates the `serviceCount` field in each category document

## Usage

To update service counts:

```bash
node scripts/update_category_service_counts.js
```

## When to Run Updates

Run the update script in these scenarios:
1. After bulk service imports
2. After manual service additions/deletions
3. Periodically (recommended: daily/weekly) to ensure accuracy

## UI Handling

- The UI displays the `serviceCount` from the category document
- If `serviceCount` is missing, it defaults to 0
- No additional queries are needed when displaying categories

## Best Practices

1. Always use the script for updating counts to ensure consistency
2. Consider scheduling regular updates
3. Monitor the script's execution time with large datasets
4. Run updates during low-traffic periods

## Error Handling

The script includes error handling and logging:
- Failed updates are logged with category IDs
- The process exits with status code 1 on errors
- Each category update is independent to prevent total failure

## Performance Considerations

- Uses Firestore's `count()` operation for efficiency
- Batches updates to minimize writes
- Updates include timestamps for tracking