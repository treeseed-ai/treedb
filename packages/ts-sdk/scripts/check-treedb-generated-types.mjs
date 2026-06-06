import fs from "node:fs";
import path from "node:path";
import { renderOpenApiTypes } from "./generate-treedb-openapi-types.mjs";

const packageRoot = path.resolve(import.meta.dirname, "..");
const outputPath = path.join(packageRoot, "src", "treedb", "generated", "openapi-types.ts");
const expected = renderOpenApiTypes();
const actual = fs.existsSync(outputPath) ? fs.readFileSync(outputPath, "utf8") : "";

if (actual !== expected) {
  console.error("TreeDB generated OpenAPI metadata is stale. Run npm run treedb:generate.");
  process.exit(1);
}

console.log("TreeDB generated OpenAPI metadata is fresh");
