FROM sonarqube:8.3-community


RUN wget \
        "https://github.com/SonarQubeCommunity/sonar-l10n-zh/releases/download/sonar-l10n-zh-plugin-8.3/sonar-l10n-zh-plugin-8.3.jar" \
        "https://binaries.sonarsource.com/Distribution/sonar-java-plugin/sonar-java-plugin-6.3.0.21585.jar"  \
        "https://binaries.sonarsource.com/Distribution/sonar-findbugs-plugin/sonar-findbugs-plugin-3.3.jar"  \
        "https://github.com/jensgerdes/sonar-pmd/releases/download/3.2.1/sonar-pmd-plugin-3.2.1.jar"  && \
    cp *.jar 

xx