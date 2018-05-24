#r "System.Web"

using System.Net;
using System.Web;
using System.Text;
using System.Globalization;
using System.Security.Cryptography;

// source: https://docs.microsoft.com/en-us/rest/api/eventhub/generate-sas-token
private static string createToken(string resourceUri, string keyName, string key)
{
    TimeSpan sinceEpoch = DateTime.UtcNow - new DateTime(1970, 1, 1);
    var week = 60 * 60 * 24 * 7;
    var expiry = Convert.ToString((int)sinceEpoch.TotalSeconds + week);
    string stringToSign = HttpUtility.UrlEncode(resourceUri) + "\n" + expiry;
    HMACSHA256 hmac = new HMACSHA256(Encoding.UTF8.GetBytes(key));
    var signature = Convert.ToBase64String(hmac.ComputeHash(Encoding.UTF8.GetBytes(stringToSign)));
    var sasToken = String.Format(CultureInfo.InvariantCulture, "SharedAccessSignature sr={0}&sig={1}&se={2}&skn={3}", HttpUtility.UrlEncode(resourceUri), HttpUtility.UrlEncode(signature), expiry, keyName);
    return sasToken;
}

public static async Task<HttpResponseMessage> Run(HttpRequestMessage req, TraceWriter log)
{
    dynamic data = await req.Content.ReadAsAsync<object>();

    string uri = data.uri;
    string name = data.name;
    string value = data.value;
    
    string token = createToken(uri, name, value);

    var response = new HttpResponseMessage(HttpStatusCode.OK);
    response.Content = new StringContent(token);
    return response;
}
