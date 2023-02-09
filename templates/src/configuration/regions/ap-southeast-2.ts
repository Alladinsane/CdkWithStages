import { RegionConfigBase } from "./region-base"


export class ApSoutheast2Config extends RegionConfigBase {
    public readonly resolverRules?: string[] = [];
    public readonly transitGatewayDefaultRouteTableId?: string = undefined;
    public readonly transitGatewayId?: string = undefined;
    public readonly transitGatewayPeeringAttachments?: { [region: string]: string } = {}
}

const config = new ApSoutheast2Config();
export { config }
