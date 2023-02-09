import { Construct } from 'constructs';
import { Organization, OrganizationProps } from '../organization';


export interface ExampleOuProps extends OrganizationProps {
    readonly dependencies?: string[];
}

export abstract class ExampleOu extends Organization {
    constructor(scope: Construct, id: string, props: ExampleOuProps) {
        super(scope, id, props);

        this.ous.push('example');
    }
}