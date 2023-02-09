import { Lazy, StageProps, Tags } from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { ExampleOu } from '..';
import { AppEnvironment } from '../../../constructs/environment';

export interface ExampleOuExampleProps extends StageProps {
    // Props 
}

export abstract class ExampleOuExample extends ExampleOu {
    // Static properties
    public static readonly AccountId: string = '123456789'; //Account Id

    // Input properties

    // Resource properties
    public readonly exampleEnvironment: AppEnvironment;
    // public readonly devVpcStack: NetworkStack;

    constructor(scope: Construct, id: string, props: ExampleOuExampleProps) {
        super(scope, id, {
            ...props, env: { ...props.env, account: ExampleOuExample.AccountId },
            accountName: 'example'
        });

       
    }
}
