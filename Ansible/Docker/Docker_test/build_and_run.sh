# this file run all playbooks of the docker image to build, deploy and run an image
# to all the configured hosts

ansible-playbook -i ../../hosts ./build_image.yaml --vault-password-file ../../password.txt 
ansible-playbook -i ../../hosts ./save_image.yaml --vault-password-file ../../password.txt 
ansible-playbook -i ../../hosts ./load_image.yaml --vault-password-file ../../password.txt 
ansible-playbook -i ../../hosts ./start_image.yaml --vault-password-file ../../password.txt 

# cleanup local stored image
rm -rf ./image