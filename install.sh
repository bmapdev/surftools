#!/usr/bin/env bash
# Install Script for surftools for Linux/MacOSX

#Copyright (C) Shantanu H. Joshi
#Brain Mapping Center, University of California Los Angeles

#__author__ = "Shantanu H. Joshi"
#__copyright__ = "Copyright 2015 Shantanu H. Joshi
#				  Ahmanson Lovelace Brain Mapping Center, University of California Los Angeles"
#__email__ = "s.joshi@g.ucla.edu"

message_if_failed() {
    #print out message and quit if last command failed
    if [ $? -ne 0 ]; then 
        echo -e >&2 $1
        exit 2
    fi
}
if [ $# -ne 1 ]
  then
    echo "usage: $0 <full path of the install directory>"
    echo "Install surftools in the specified directory."
    exit 0
fi

echo "This will install the surftools package. "
echo "This will also install a mini version of anaconda python"

# Check if curl exists
curl --help >> /dev/null
curl_exists=$?
if [ ${curl_exists} != 0 ]; then
    printf "\nThe program curl is not installed. Please install curl and retry installing the toolbox.\n"
    exit 0
fi

VER=3.7.3
orig_dir=`pwd`
install_dir=$1

if [ -d "$install_dir" ]; then
	echo "Directory $install_dir exists. Aborting installation."
	exit 0
fi

mkdir "$install_dir"
mkdir "$install_dir"/"tmp"

osname=`uname`
if [[ "$osname" == "Darw"* ]]; then
	platform="MacOSX"
else
	platform="Linux"
fi;

echo "Downloading anaconda python...This may take a few minutes..."
curl -o ${install_dir}/tmp/Miniconda-${VER}-${platform}-x86_64.sh http://repo.continuum.io/miniconda/Miniconda-${VER}-${platform}-x86_64.sh
chmod +x ${install_dir}/tmp/Miniconda-${VER}-${platform}-x86_64.sh
echo "Done."
echo -n "Installing anaconda python..."
${install_dir}/tmp/Miniconda-${VER}-${platform}-x86_64.sh -b -f -p ${install_dir} 1> ${install_dir}/tmp/install.log
echo "Done."

${install_dir}/bin/conda install conda==3.7.4 -q --yes 1>> ${install_dir}/tmp/install.log

${install_dir}/bin/conda install pip==1.5.6 -q --yes 1>> ${install_dir}/tmp/install.log

echo -n "Installing statsmodels...This may take a few minutes..."
${install_dir}/bin/conda install statsmodels==0.6.0 -q --yes 1>> ${install_dir}/tmp/install.log
echo "Done."

echo -n "Installing shapeio..."
${install_dir}/bin/pip install https://github.com/bmapdev/shapeio/archive/master.zip
echo "Done."

echo -n "Installing vtk...This may take a few minutes..."
${install_dir}/bin/conda install vtk==5.10.1 -q --yes 1>> ${install_dir}/tmp/install.log
echo "Done."

echo -n "Installing nibabel..."
${install_dir}/bin/pip install nibabel==2.0.0>> ${install_dir}/tmp/install.log
echo "Done."

echo -n "Installing surftools..."
${install_dir}/bin/pip install https://github.com/bmapdev/surftools/archive/master.zip
echo "Done."

if [[ "$platform" == "Linux" ]]; then
    ${install_dir}/bin/conda remove -q --yes readline >> ${install_dir}/tmp/install.log # This is a workaround for the "libreadline.so not found" error. Temporary fix.
fi;

if [[ ${install_dir} = /* ]];
then
    # Absolute path
    install_bin_abs_path="${install_dir}/bin"
else
    # Relative path
    install_bin_abs_path=$(echo $PWD/$(basename ${install_dir})"/bin")
fi


if [[ -f ~/.bashrc ]]
then
    printf "Making a backup of the ~/.bashrc to ~/.bashrc.BAK just in case\n"
    cp ~/.bashrc ~/.bashrc.BAK
fi

if [[ "$platform" == "Linux" ]]; then
    unset R_HOME
    R_HOME=`R RHOME`
    read -p "Would you like to modify your ~/.bashrc to add the path ${R_HOME} to LD_LIBRARY_PATH? [y/n] " yn

    case $yn in
        [Yy]* )
            echo "export LD_LIBRARY_PATH=${R_HOME}/lib:\${LD_LIBRARY_PATH}" >> ~/.bashrc;
            printf "Modified ~/.bashrc\n";;
        [Nn]* )
            printf "~/.bashrc not modified. You may have to set the LD_LIBRARY_PATH manually as\n";
            printf "export LD_LIBRARY_PATH=${R_HOME}/lib:\${LD_LIBRARY_PATH}\n";;
        * )
            printf "~/.bashrc not modified. You may have to set the LD_LIBRARY_PATH manually as\n";
            printf "export LD_LIBRARY_PATH=${R_HOME}/lib:\${LD_LIBRARY_PATH}\n";;
    esac
    echo "export LD_LIBRARY_PATH=${R_HOME}/lib:\${LD_LIBRARY_PATH}\n" 1>> ${install_dir}/tmp/install.log
fi

read -p "Would you like to modify your ~/.bashrc PATH to include the path ${install_bin_abs_path}? [y/n] " yn
case $yn in
    [Yy]* )
            echo "export PATH=${install_bin_abs_path}:\${PATH}" >> ~/.bashrc;
            printf "Modified ~/.bashrc to add the path ${install_bin_abs_path}\n";;
    [Nn]* )
            printf "~/.bashrc not modified. You may either have to set the PATH manually,\n";
            printf "or run the commands from ${install_dir}/bin\n";
            printf "export PATH=${install_bin_abs_path}:\${PATH}\n";;
    * )
            printf "~/.bashrc not modified. You may either have to set the PATH manually,\n";
            printf "or run the commands from ${install_dir}/bin\n";
            printf "export PATH=${install_bin_abs_path}:\${PATH}\n";;
esac

echo "export PATH=${install_bin_abs_path}:\${PATH}\n" 1>> ${install_dir}/tmp/install.log

printf "Surftools was installed successfully.\n"
printf "Cleaning up temporary files..."
rm -r ${install_dir}/pkgs/
rm -r ${install_dir}/tmp/Miniconda-${VER}-${platform}-x86_64.sh
printf "Done.\n\n"

printf "To test...\n"
printf "Run source ~/.bashrc if you modified your bashrc.\n"
if [[ "$platform" == "Linux" ]]; then
    printf "Or set the LD_LIBRARY_PATH manually as shown above.\n"
fi
printf "Try running\n ${install_dir}/bin/register_surface.py -h \n"
printf "It should display help and then exit.\n\n\n"

exit 0
