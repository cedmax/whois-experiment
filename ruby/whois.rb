require "redis"
require "whois"
require "json_builder"

$redis = Redis.new(:timeout => 0, :port => 32733)
$redis1 = Redis.new(:timeout => 0, :port => 32733)

def serialize_contact(contacts)
   if contacts
        array contacts do |contact|
            name contact.send(:name)
            email contact.send(:email)
            organization contact.send(:organization)
            location contact.send(:country_code)
        end
    else
        nil
    end
end

def serialize_status(status)
   if status.kind_of?(Array)
        array status
    else
        array ["#{status}"]
    end
end

$redis.subscribe('whois') do |on|
    on.message do |channel, msg|
	puts msg
        w = Whois.whois(msg)
        json = JSONBuilder::Compiler.generate do
            domain msg
            status do
                serialize_status w.status
            end
            registered w.registered?
            available w.available?
            created_on w.created_on.to_i
            updated_on w.updated_on.to_i
            expires_on w.expires_on.to_i
            nameservers w.nameservers.map { |ns| ns.to_s }
            registrar do
               name w.registrar.send(:name)
               id w.registrar.send(:id)
               url w.registrar.send(:url)
            end
            registrant_contacts do
                serialize_contact(w.registrant_contacts)
            end
            admin_contacts do
                serialize_contact(w.admin_contacts)
            end
            technical_contacts do
                serialize_contact(w.technical_contacts)
            end
        end
    $redis1.publish('whois-result',json)
    end
end
