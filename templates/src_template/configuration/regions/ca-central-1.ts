import { RegionConfigBase } from "./region-base"


export class CaCentral1Config extends RegionConfigBase {
    public readonly resolverRules?: string[] = ['rslvr-autodefined-rr-internet-resolver'];
    public readonly transitGatewayDefaultRouteTableId?: string = 'tgw-rtb-02a696f26bf6b6aff';
    public readonly transitGatewayId?: string = 'tgw-0eb18fcb4c84e7053';
    public readonly transitGatewayPeeringAttachments?: { [region: string]: string } = {'us-east-1': 'tgw-attach-0ffc462867c152bdf'}
}

const config = new CaCentral1Config();
export { config }
