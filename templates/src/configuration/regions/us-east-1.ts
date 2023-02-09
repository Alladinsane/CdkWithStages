import { RegionConfigBase } from "./region-base"


export class UsEast1Config extends RegionConfigBase {
    public readonly resolverRules?: string[] = ['rslvr-autodefined-rr-internet-resolver'];
    public readonly transitGatewayDefaultRouteTableId?: string = 'tgw-rtb-0384ddcac9adaba74';
    public readonly transitGatewayId?: string = 'tgw-065eafdef15bf9a02';
    public readonly transitGatewayPeeringAttachments?: { [region: string]: string } = {'ca-central-1': 'tgw-attach-0ffc462867c152bdf'}
}

const config = new UsEast1Config();
export { config }