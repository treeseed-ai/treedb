import type { TreeDbClient } from '../client/TreeDbClient.js';

export interface TreeDbConformanceAdapterOptions {
  client: TreeDbClient;
  serverConfigured?: boolean;
}

export interface TreeDbConformanceScenario {
  id: string;
  capabilityId: string;
  title: string;
  required: boolean;
  endpointRefs: string[];
  steps: Array<{ name: string; action: string; description: string }>;
  assertions: string[];
}

export interface TreeDbConformanceResult {
  scenarioId: string;
  status: 'passed' | 'failed' | 'not_configured';
  message?: string;
}

export class TreeDbConformanceAdapter {
  constructor(private readonly options: TreeDbConformanceAdapterOptions) {}

  async runScenario(scenario: TreeDbConformanceScenario): Promise<TreeDbConformanceResult> {
    void this.options.client;
    if (!this.options.serverConfigured) {
      return {
        scenarioId: scenario.id,
        status: 'not_configured',
        message: 'TreeDB server is not configured for TypeScript conformance execution'
      };
    }

    return {
      scenarioId: scenario.id,
      status: 'not_configured',
      message: 'Executable TypeScript conformance dispatch is deferred to a later phase'
    };
  }
}
