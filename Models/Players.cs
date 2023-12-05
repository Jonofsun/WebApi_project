namespace WebApi_project.Models;

public class Players
{
    public int PlayerID {get; set;}

    public string PlayerName {get; set;}

    public string Class { get; set; }

    public int PlayerLevel {get; set;}

    public DateTime RegistrationDate {get; set;}

    public int LocationID {get; set;}

    public int PlayerLoginID {get; set;}

}