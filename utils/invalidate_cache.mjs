import { CloudFrontClient, CreateInvalidationCommand } from '@aws-sdk/client-cloudfront';

const client = new CloudFrontClient({ region: 'us-east-2' });

export const handler = async (event) => {
    try {
        const distributionId = process.env.DISTRIBUTION_ID;
        if (!distributionId) {
            throw new Error('DISTRIBUTION_ID environment variable is not set');
        }

        // Create invalidation for all files
        const params = {
            DistributionId: distributionId,
            InvalidationBatch: {
                CallerReference: `codepipeline-invalidation-${Date.now()}`, // Unique identifier
                Paths: {
                    Quantity: 1,
                    Items: ['/*'] // Invalidate all files
                }
            }
        };

        const command = new CreateInvalidationCommand(params);
        const response = await client.send(command);

        return {
            statusCode: 200,
            body: JSON.stringify({
                message: 'CloudFront cache invalidation created successfully',
                invalidationId: response.Invalidation.Id,
                distributionId
            })
        };
    } catch (error) {
        console.error('Error creating CloudFront invalidation:', error);
        return {
            statusCode: 500,
            body: JSON.stringify({
                error: 'Failed to create CloudFront invalidation',
                details: error.message
            })
        };
    }
};