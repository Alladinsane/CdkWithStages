import { config as usEast1Config } from "./us-east-1";
import { config as caCentral1Config } from "./ca-central-1";
import { config as apSoutheast2Config } from "./ap-southeast-2";
import { RegionConfigBase } from "./region-base"


const RegionConfigs: { [region: string]: RegionConfigBase } = {
    ['us-east-1']: usEast1Config,
    ['ca-central-1']: caCentral1Config,
    ['ap-southeast-2']: apSoutheast2Config
}

export { RegionConfigs }