sudo apt update
sudo apt install -y libltdl7 libseccomp2
mkdir Downloads
wget --no-verbose --directory-prefix=Downloads https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64/docker-ce_18.03.0~ce-0~ubuntu_amd64.deb
sudo dpkg -i /home/ubuntu/Downloads/docker-ce_18.03.0~ce-0~ubuntu_amd64.deb
sudo usermod -aG docker ubuntu
