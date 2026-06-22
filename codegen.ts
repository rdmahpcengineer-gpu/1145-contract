// graphql-codegen config: CP-3 live-feed SDL -> TS types for the frontend dashboard.
// AWS scalars map to their JSON wire representation (AWSDateTime/AWSPhone are ISO/E.164 strings).
import type { CodegenConfig } from "@graphql-codegen/cli";

const config: CodegenConfig = {
  // appsync-aws.graphql first so the AppSync scalars/directives are declared before schema.graphql.
  schema: ["graphql/appsync-aws.graphql", "graphql/schema.graphql"],
  generates: {
    "gen/ts/graphql.ts": {
      plugins: ["typescript"],
      config: {
        enumsAsTypes: true,
        useTypeImports: true,
        scalars: {
          AWSDateTime: "string",
          AWSDate: "string",
          AWSTime: "string",
          AWSTimestamp: "number",
          AWSEmail: "string",
          AWSPhone: "string",
          AWSURL: "string",
          AWSIPAddress: "string",
          AWSJSON: "string",
        },
      },
    },
  },
};

export default config;
