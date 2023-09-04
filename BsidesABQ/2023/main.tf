resource "aws_iam_role" "cloudtrail_role" {
  name = "cloudtrail-role"

  assume_role_policy = jsonencode({
    principals: [
      {
        type: "Service",
        identifiers: ["cloudtrail.amazonaws.com"]
      }
    ],
    actions: ["sts:AssumeRole"]
  })

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "CloudTrailFullAccess",
        "Effect": "Allow",
        "Action": [
          "cloudtrail:*"
        ],
        "Resource": *
      },
      {
        "Sid": "IAMListingAccess",
        "Effect": "Allow",
        "Action": [
          "iam:ListAccount",
          "iam:ListUsers"
        ],
        "Resource": "*"
      },
      {
        "Sid": "IAMListingAccessAccount",
        "Effect": "Allow",
        "Action": [
          "iam:ListAccount"
        ],
        "Resource": ["arn:aws:iam::882583340145:user/Abumuslim"]
      }
    ]
  })
}

resource "aws_iam_user" "cloudtrail_user" {
  name = "cloudtrail-user"
}

resource "aws_iam_user_policy_attachment" "cloudtrail_user_policy_attachment" {
  user = aws_iam_user.cloudtrail_user.name
  policy_arn = aws_iam_role.cloudtrail_role.arn
}

resource "aws_cloudtrail" "default" {
  name = "my-cloudtrail"
  bucket = "my-cloudtrail-bucket"
  enable_log_file_validation = true

  delegated_administrators = ["882583340145"]

  linked_service_channels = [
    {
      name = "my-linked-service-channel"
      channel_name = "my-channel"
    }
  ]

  event_data_store {
    name = "my-event-data-store"
    s3_bucket_arn = "my-cloudtrail-data-bucket"
  }

  role_arn = aws_iam_role.cloudtrail_role.arn
}

resource "aws_cloudtrail_event_subscription" "default" {
  name = "my-cloudtrail-event-subscription"
  trail_arn = aws_cloudtrail.default.arn
  destination_config {
    s3_bucket_arn = "my-cloudtrail-data-bucket"
  }
}

