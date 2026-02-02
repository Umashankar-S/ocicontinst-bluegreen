# OCICONTINST-BLUE-GREEN

- This  project deploys OCI Container instances in a Blue Green deployment architecture.

- Repo also creates the Network components ( VCN , Subnets, Routing ,NSG) & Load balancer

- This project can be deployed via OCI resource manager stack (ORM) and Terraform 

- Its idle to use  ORM stack  as future updates for Blue Green deployment can be triggered by ORM Stack variable updates   either via 
 - OCI function (Reference Repo )
 - Manual Update of ORM Stack

## Architecture 

<img width="1098" height="583" alt="image" src="https://github.com/user-attachments/assets/487f0cf8-5683-47d3-b9c2-0c7cb66f9cf6" />


## Prerequisites

1. Required IAM Policies and Group  [ User is part of group with below permissions ]

Allow group <identity_domain_name>/<group-name> to manage orm-family in compartment id  <comp_ocid>

Allow group <identity_domain_name>/<group-name> to manage compute-container-family in compartment id  <comp_ocid>
Allow group <identity_domain_name>/<group-name> to manage virtual-network-family  in compartment id  <comp_ocid>

Allow group <identity_domain_name>/<group-name> to manage repos in compartment id  <comp_ocid>

Allow group <identity_domain_name>/<group-name>to manage log-content in compartment id  <comp_ocid>

## Loadbalancer related policies 

Allow service loadbalancer to use network-security-groups in compartment id  <comp_ocid>

Allow service loadbalancer to use vnics in compartment id <comp_ocid>

Allow dynamic-group <identity_domain_name>/<dynamic-group-name> to manage  load-balancers in compartment id <comp_ocid>



## Deploy Using Oracle Resource Manager

1. Click [![Deploy to Oracle Cloud](https://oci-resourcemanager-plugin.plugins.oci.oraclecloud.com/latest/deploy-to-oracle-cloud.svg)](https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=https://github.com/Umashankar-S/ocicontinst-bluegreen/archive/refs/heads/main.zip)


    If you aren't already signed in, when prompted, enter the tenancy and user credentials.

2. Review and accept the terms and conditions.

3. Select the region where you want to deploy the stack.

4. Follow the on-screen prompts and instructions to create the stack.

5. After creating the stack, click **Terraform Actions**, and select **Plan**.

6. Wait for the job to be completed, and review the plan.

    To make any changes, return to the Stack Details page, click **Edit Stack**, and make the required changes. Then, run the **Plan** action again.

7. If no further changes are necessary, return to the Stack Details page, click **Terraform Actions**, and select **Apply**. 
