import * as cdk from 'aws-cdk-lib';
import { StackProps } from 'aws-cdk-lib';
import { Construct } from 'constructs';
import { ExampleOuExample } from '..';

export interface ExampleOuExampleUsEast1Props extends StackProps {
    readonly dependencies?: string[];
}

export class PicabooDevCaCentral1 extends ExampleOuExample {

    constructor(scope: Construct, id: string, props: ExampleOuExampleUsEast1Props = {}) {
        super(scope, id, {
            ...props, env: { region: 'us-east-1' }
        });
    }
}
