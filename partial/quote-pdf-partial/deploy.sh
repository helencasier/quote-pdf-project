#!/bin/bash

set -e  # Exit on first error

echo "🚀 Deploying Quote PDF components to sandbox5..."

# Check if sandbox5 is authorized
if ! sf org display --target-org sandbox5 > /dev/null 2>&1; then
    echo "🔑 sandbox5 is not authorized. Please authenticate first:"
    echo "👉 sf org login web --instance-url https://test.salesforce.com --alias sandbox5"
    exit 1
fi

# Deploy using manifest
sf project deploy start \
  --manifest manifest/package.xml \
  --target-org sandbox5 \
  --test-level RunLocalTests \
  --wait 10 \
  --verbose

if [ $? -eq 0 ]; then
    echo "✅ Deployment to sandbox5 succeeded!"

    #### OPTION 1: Quick-only test data creation (uncomment to use)
    # echo "🧪 Running Quick Test Data creation in sandbox5..."
    # sf apex run --target-org sandbox5 --code "TestDataFactory.createQuickTestData();" --wait 5
    # if [ $? -eq 0 ]; then
    #     echo "✅ Quick Test Data created successfully in sandbox5!"
    # else
    #     echo "⚠️ Quick Test Data creation failed in sandbox5!"
    # fi

    #### OPTION 2: Prompt for Quick or Robust test data creation
    read -p "🤔 Run Quick (1) or Robust (2) test data? [1/2]: " choice
    if [ "$choice" == "1" ]; then
        testMethod="TestDataFactory.createQuickTestData();"
    else
        testMethod="TestDataFactory.createRobustTestData();"
    fi

    echo "🧪 Running $testMethod in sandbox5..."
    sf apex run --target-org sandbox5 --code "$testMethod" --wait 5

    if [ $? -eq 0 ]; then
        echo "✅ Test data created successfully in sandbox5!"
    else
        echo "⚠️ Test data creation failed in sandbox5!"
    fi

else
    echo "❌ Deployment failed!"
    exit 1
fi
