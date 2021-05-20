// import hudson.markup.RawHtmlMarkupFormatter
// import hudson.security.HudsonPrivateSecurityRealm
// import hudson.security.FullControlOnceLoggedInAuthorizationStrategy
// import hudson.security.csrf.DefaultCrumbIssuer
// import jenkins.model.Jenkins

import jenkins.*
import hudson.*
import hudson.model.*
import hudson.markup.*
import hudson.security.*
import hudson.security.csrf.*
import hudson.plugins.sshslaves.*;
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*

import jenkins.model.*



def instance = Jenkins.instanceOrNull

// =====================================================================================================================
// Allow html markup with syntax highlighting
// =====================================================================================================================
instance.setMarkupFormatter(new RawHtmlMarkupFormatter(false))


// =====================================================================================================================
// Enable CSRF protection (see: https://wiki.jenkins.io/display/JENKINS/CSRF+Protection)
// public DefaultCrumbIssuer(boolean excludeClientIPFromCrumb)
// =====================================================================================================================
instance.setCrumbIssuer(new DefaultCrumbIssuer(true))


// =====================================================================================================================
//  Setting Default NumExecutors
// =====================================================================================================================
instance.setNumExecutors(10)


// =====================================================================================================================
//  Setting Default ScmCheckoutRetryCount
// =====================================================================================================================
instance.setScmCheckoutRetryCount(5)


// =====================================================================================================================
// Setting Default QuietPeriod
// public void setQuietPeriod(Integer quietPeriod)
// =====================================================================================================================
instance.setQuietPeriod(5)


// =====================================================================================================================
// Create credentials
// =====================================================================================================================

global_domain = Domain.global()
credentials_store =
  Jenkins.instance.getExtensionList(
    'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
  )[0].getStore()

def credentials = null
// credentials = new BasicSSHUserPrivateKey(CredentialsScope.GLOBAL,null,"root",new BasicSSHUserPrivateKey.UsersPrivateKeySource(),"","")
// credentials_store.addCredentials(global_domain, credentials)

credentials = new UsernamePasswordCredentialsImpl(CredentialsScope.GLOBAL, "1", "jenkins", "jenkins", "jenkins123")
credentials_store.addCredentials(global_domain, credentials)

credentials = new UsernamePasswordCredentialsImpl(CredentialsScope.GLOBAL, "scmmanager", "scmmanager", "scmadmin", "scmadmin")
credentials_store.addCredentials(global_domain, credentials)

// =====================================================================================================================
// Create the admin user
// =====================================================================================================================
def adminUsername = System.getenv('JENKINS_ADMIN_USERNAME') ?: 'admin'
try {
    instance.getSecurityRealm().loadUserByUsername(adminUsername)
} catch(Exception e) {
    //
    println "Create the user: $adminUsername"
    def jenkinsRealm = new HudsonPrivateSecurityRealm(false)
    // def adminUsername = System.getenv('JENKINS_ADMIN_USERNAME') ?: 'admin'
    def adminPassword = System.getenv('JENKINS_ADMIN_PASSWORD') ?: 'admin123'
    jenkinsRealm.createAccount(adminUsername, adminPassword)
    //
    instance.setSecurityRealm(jenkinsRealm)
}

// 1
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

// 2
// def strategy = new GlobalMatrixAuthorizationStrategy()
// //  Slave Permissions
// //strategy.add(hudson.model.Computer.BUILD,'charles')
// //strategy.add(hudson.model.Computer.CONFIGURE,'charles')
// //strategy.add(hudson.model.Computer.CONNECT,'charles')
// //strategy.add(hudson.model.Computer.CREATE,'charles')
// //strategy.add(hudson.model.Computer.DELETE,'charles')
// //strategy.add(hudson.model.Computer.DISCONNECT,'charles')

// //  Credential Permissions
// //strategy.add(com.cloudbees.plugins.credentials.CredentialsProvider.CREATE,'charles')
// //strategy.add(com.cloudbees.plugins.credentials.CredentialsProvider.DELETE,'charles')
// //strategy.add(com.cloudbees.plugins.credentials.CredentialsProvider.MANAGE_DOMAINS,'charles')
// //strategy.add(com.cloudbees.plugins.credentials.CredentialsProvider.UPDATE,'charles')
// //strategy.add(com.cloudbees.plugins.credentials.CredentialsProvider.VIEW,'charles')

// //  Overall Permissions
// //strategy.add(hudson.model.Hudson.ADMINISTER,'charles')
// //strategy.add(hudson.PluginManager.CONFIGURE_UPDATECENTER,'charles')
// //strategy.add(hudson.model.Hudson.READ,'charles')
// //strategy.add(hudson.model.Hudson.RUN_SCRIPTS,'charles')
// //strategy.add(hudson.PluginManager.UPLOAD_PLUGINS,'charles')

// //  Job Permissions
// //strategy.add(hudson.model.Item.BUILD,'charles')
// //strategy.add(hudson.model.Item.CANCEL,'charles')
// //strategy.add(hudson.model.Item.CONFIGURE,'charles')
// //strategy.add(hudson.model.Item.CREATE,'charles')
// //strategy.add(hudson.model.Item.DELETE,'charles')
// //strategy.add(hudson.model.Item.DISCOVER,'charles')
// //strategy.add(hudson.model.Item.READ,'charles')
// //strategy.add(hudson.model.Item.WORKSPACE,'charles')

// //  Run Permissions
// //strategy.add(hudson.model.Run.DELETE,'charles')
// //strategy.add(hudson.model.Run.UPDATE,'charles')

// //  View Permissions
// //strategy.add(hudson.model.View.CONFIGURE,'charles')
// //strategy.add(hudson.model.View.CREATE,'charles')
// //strategy.add(hudson.model.View.DELETE,'charles')
// //strategy.add(hudson.model.View.READ,'charles')

// //  Setting Anonymous Permissions
// // strategy.add(hudson.model.Hudson.READ,'anonymous')
// // strategy.add(hudson.model.Item.BUILD,'anonymous')
// // strategy.add(hudson.model.Item.CANCEL,'anonymous')
// // strategy.add(hudson.model.Item.DISCOVER,'anonymous')
// // strategy.add(hudson.model.Item.READ,'anonymous')

// // Setting Admin Permissions
// strategy.add(Jenkins.ADMINISTER, "admin")

// // Setting Dev Permissions
// strategy.add(hudson.model.Hudson.READ,'dev')
// strategy.add(hudson.model.Item.BUILD,'dev')
// strategy.add(hudson.model.Item.CANCEL,'dev')
// strategy.add(hudson.model.Item.DISCOVER,'dev')
// strategy.add(hudson.model.Item.READ,'dev')

// // Setting easy settings for local builds
// def local = System.getenv("BUILD").toString()
// if(local == "local") {
//   //  Overall Permissions
//   strategy.add(hudson.model.Hudson.ADMINISTER,'anonymous')
//   strategy.add(hudson.PluginManager.CONFIGURE_UPDATECENTER,'anonymous')
//   strategy.add(hudson.model.Hudson.READ,'anonymous')
//   strategy.add(hudson.model.Hudson.RUN_SCRIPTS,'anonymous')
//   strategy.add(hudson.PluginManager.UPLOAD_PLUGINS,'anonymous')
// }

// instance.setAuthorizationStrategy(strategy)

// =====================================================================================================================
// Save everything
// =====================================================================================================================
instance.save()
