#!/bin/bash -x

num_np_hosts=3
declare -a np_hostname=(
np-odb-a
np-odb-b
np-odb-c
)
declare -a np_rootpwdname=(
EPV/ODB-A/NonProdSafe/DBuser/password
EPV/ODB-B/NonProdSafe/DBuser/password
EPV/ODB-C/NonProdSafe/DBuser/password
)

for ((i=0;i<num_np_hosts;i++)) do
  ./add-host.sh non-prod/hosts ${np_hostname[$i]} ${np_rootpwdname[$i]}
done


num_p_hosts=3
declare -a p_hostname=(
p-odb-a
p-odb-b
p-odb-c
)
declare -a p_rootpwdname=(
EPV/ODB-A/ProdSafe/DBuser/password
EPV/ODB-B/ProdSafe/DBuser/password
EPV/ODB-C/ProdSafe/DBuser/password
)

for ((i=0;i<num_p_hosts;i++)) do
  ./add-host.sh prod/hosts ${p_hostname[$i]} ${p_rootpwdname[$i]}
done
