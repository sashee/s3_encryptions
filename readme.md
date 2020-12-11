get no encryption:

```
npx -q awsudo $(terraform output -json | jq -r '."access-bucket-role".value') aws s3api get-object --bucket $(terraform output -json | jq -r '.bucket.value') --key $(terraform output -json | jq -r '."no_encryption".value') /dev/stderr > /dev/null
No encryption% 
```

get sse-s3:

```
npx -q awsudo $(terraform output -json | jq -r '."access-bucket-role".value') aws s3api get-object --bucket $(terraform output -json | jq -r '.bucket.value') --key $(terraform output -json | jq -r '."sse-s3".value') /dev/stderr > /dev/null
SSE-S3% 
```

get sse-kms default key:

```
npx -q awsudo $(terraform output -json | jq -r '."access-bucket-role".value') aws s3api get-object --bucket $(terraform output -json | jq -r '.bucket.value') --key $(terraform output -json | jq -r '."sse-kms-default".value') /dev/stderr > /dev/null
SSE-KMS with default CMK% 
```

get sse-kms customer managed key:

```
npx -q awsudo $(terraform output -json | jq -r '."access-bucket-role".value') aws s3api get-object --bucket $(terraform output -json | jq -r '.bucket.value') --key $(terraform output -json | jq -r '."sse-kms-customer-managed".value') /dev/stderr > /dev/null

An error occurred (AccessDenied) when calling the GetObject operation: Access Denied
```

get sse-kms customer managed key with permissions for the key:

```
npx -q awsudo $(terraform output -json | jq -r '."access-key-role".value') aws s3api get-object --bucket $(terraform output -json | jq -r '.bucket.value') --key $(terraform output -json | jq -r '."sse-kms-customer-managed".value') /dev/stderr > /dev/null
SSE-KMS with customer-managed CMK% 
```


put sse-c:

```
aws s3api put-object --bucket $(terraform output -json | jq -r '.bucket.value') --key "text.txt" --body text.txt --sse-customer-algorithm "AES256" --sse-customer-key gL6RsUG2fPElqDyMghs1yCrRJMJFLgR9MN/Z8vjALUI= --sse-customer-key-md5 XaroTmmABjK75669+kj/xw==
```

get sse-c:

```
aws s3api get-object --bucket $(terraform output -json | jq -r '.bucket.value') --key "text.txt" --sse-customer-algorithm "AES256" --sse-customer-key gL6RsUG2fPElqDyMghs1yCrRJMJFLgR9MN/Z8vjALUI= --sse-customer-key-md5 XaroTmmABjK75669+kj/xw== /dev/stderr > /dev/null
```

wrong get:

```
aws s3api get-object --bucket $(terraform output -json | jq -r '.bucket.value') --key "text.txt" --sse-customer-algorithm "AES256" --sse-customer-key gi6MmyZp6Vvz+gf7r4s349nXjcPUUU0JH5gwfYufsqs= --sse-customer-key-md5 qqHzshF3ZcyKffalGwi9AQ== /dev/stderr > /dev/null

Access Denied
```

no parameters:

```
An error occurred (InvalidRequest) when calling the GetObject operation: The object was stored using a form of Server Side Encryption. The correct parameters must be provided to retrieve the object.
```
