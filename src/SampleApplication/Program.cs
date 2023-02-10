using Amazon.SimpleNotificationService;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;

var builder = WebApplication.CreateBuilder(args);

var aws = builder.Configuration.GetAWSOptions();

builder.Configuration.AddSystemsManager("/samples/iam-role/", aws);

builder.Services.AddDefaultAWSOptions(aws);

builder.Services.AddAWSService<IAmazonSimpleNotificationService>();

builder.Services.Configure<SNSOptions>(builder.Configuration);

var app = builder.Build();

app.MapGet("/", () => "Hello World!");

app.MapPost("/send-message", async (IAmazonSimpleNotificationService sns, IOptions<SNSOptions> options, [FromBody] string message) =>
{
    var response = await sns.PublishAsync(options.Value.TopicArn, message);

    return Results.Ok(response.MessageId);
});

app.Run();

public class SNSOptions
{
    public required string TopicArn { get; init; }
}