FROM oraclelinux:7
MAINTAINER Mario Cairone <mario.cairone@gmail.com>

ENV NGIX_URL http://<ngix url and port>/files/soa

ENV _SCRATCH /tmp/scratch
ENV ORA_HOME /home/oracle
ENV JDK_HOME ${ORA_HOME}/jdk
ENV FMW_HOME ${ORA_HOME}/product/12.2.1/fmw
ENV JDEV_USER_DIR ${ORA_HOME}/jdeveloper

#SAVE the name of the downloaded files in vars
ENV JDK_FILE jdk-8u77-linux-x64.tar.gz
ENV SOA_ZIP  fmw_12.2.1.0.0_soaqs_Disk1_1of2.zip
ENV SOA_ZIP2 fmw_12.2.1.0.0_soaqs_Disk1_2of2.zip
ENV RSP_FILE silent.rsp


RUN	yum install -y -q xorg-x11-apps xauth libXtst tar unzip && \
	groupadd -g 1000 oinstall && \
	useradd -u 1000 -g 1000 -m oracle && \
	mkdir -p ${ORA_HOME} && \
	mkdir -p ${_SCRATCH} && \
	chown -R oracle:oinstall ${_SCRATCH} && \
	chown -R oracle:oinstall ${ORA_HOME}
	
USER oracle

RUN curl -o  ${_SCRATCH}/${SOA_ZIP} ${NGIX_URL}/${SOA_ZIP} && \
	curl -o  ${_SCRATCH}/${SOA_ZIP2} ${NGIX_URL}/${SOA_ZIP2} && \
	curl -o  ${_SCRATCH}/${JDK_FILE} ${NGIX_URL}/${JDK_FILE} && \
	curl -o  ${_SCRATCH}/${RSP_FILE} ${NGIX_URL}/${RSP_FILE} && \
	mkdir -p ${JDK_HOME} ${FMW_HOME} && \
	echo "inventory_loc=${FMW_HOME}/oraInventory" > ${_SCRATCH}/oraInst.loc && \
	echo "inst_group=oinstall" >> ${_SCRATCH}/oraInst.loc && \
	tar xzf ${_SCRATCH}/jdk-8u77-linux-x64.tar.gz -C ${JDK_HOME} --strip-components=1 && \
	rm -rf ${_SCRATCH}/jdk-8u77-linux-x64.tar.gz && \
	unzip ${_SCRATCH}/fmw_12.2.1.0.0_soaqs_Disk1_1of2.zip -d ${_SCRATCH} && \
	unzip ${_SCRATCH}/fmw_12.2.1.0.0_soaqs_Disk1_2of2.zip -d ${_SCRATCH} && \
	${JDK_HOME}/bin/java -jar ${_SCRATCH}/fmw_12.2.1.0.0_soa_quickstart.jar \
	-novalidation -silent -responseFile ${_SCRATCH}/silent.rsp \
	-invPtrLoc ${_SCRATCH}/oraInst.loc ORACLE_HOME=${FMW_HOME} && \
	rm -rf ${_SCRATCH}/fmw_12.2.1.0.0_soaqs_Disk1_1of2.zip \
	${_SCRATCH}/fmw_12.2.1.0.0_soaqs_Disk1_2of2.zip \
	${_SCRATCH}/fmw_12.2.1.0.0_soa_quickstart.jar \
	${_SCRATCH}/fmw_12.2.1.0.0_soa_quickstart2.jar; \
	rm -rf ${_SCRATCH}

ENV PATH $PATH:${FMW_HOME}/oracle_common/bin:${FMW_HOME}/oracle_common/common/bin:${FMW_HOME}/jdeveloper/jdev/bin:${FMW_HOME}/soa/common/bin/


CMD /bin/bash