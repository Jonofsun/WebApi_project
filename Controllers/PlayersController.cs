using Dapper;
using WebApi_project.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Data.SqlClient;

namespace WebApi_project.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PlayersController : ControllerBase
    {
        string connectionString;
        public PlayerController(IConfiguration configuration)
        {
            connectionString = configuration.GetConnectionString("DefaultConnection");
        }
        //get
        
        [HttpGet]
        public ActionResult<List<Players>> GetAllPlayers()
        {
            using SqlConnection connection = new SqlConnection(connectionString);
            List<Players> players = connection.Query<Players>("Select * from RPG.Players").ToList();
            return Ok(players);
        }
        //get with an id
        [HttpGet("{id}")]
        public ActionResult<Players> GetPlayers(int id)
        {
            if(id < 1)
            {
                return BadRequest();
            }
            using SqlConnection connection = new SqlConnection(connectionString);
            Players players = connection.QueryFirstOrDefault<Players>("SELECT * FROM RPG.Players WHERE PlayerID = @Id", new {Id = id});
            if(players == null)
            {
                return NotFound();
            }
            return Ok(players);
        }
        //POST - Create
        //Put - Update
        //Delete - Delete
        [HttpPost]
        public ActionResult<Players> CreatePlayer(Players players)
        {
            
            if(players.PlayerLoginID < 1)
            {
                return BadRequest();
            }
            using SqlConnection connection = new SqlConnection(connectionString);
            PlayerLogin playerLogin = connection.QueryFirstOrDefault<PlayerLogin>("SELECT * FROM RPG.PlayerLogin " +
            "WHERE PlayerLoginID = @Id", new { Id = players.PlayerLoginID });
            if (playerLogin == null)
            {
                return BadRequest();
            }
            try
            {
                //SCOPE_IDENTITY() this gets you the primary key of the newly created object
                Players newPlayers = connection.QuerySingle<Players>(
                    "INSERT INTO RPG.Players ([Name], Class, [Level], RegistrationDate, LocationID, PlayerLoginID) VALUES (@[Name], @Class, @[Level], @RegistrationDate, @LocationID, @PlayerLoginID); " +
                    "SELECT * FROM RPG.Players WHERE PlayerID = SCOPE_IDENTITY();", players);
                return Ok(newPlayers);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                return BadRequest();
            }
        }
        //PUT
        [HttpPut("{id}")]
        public ActionResult<Players> UpdatePlayers(int id, Players players)
        {
            if(id < 1)
            {
                return BadRequest();
            }
            players.PlayerID = id;
            using SqlConnection connection = new SqlConnection(connectionString);
            
            PlayerLogin playerLogin = connection.QueryFirstOrDefault<PlayerLogin>("SELECT * FROM RPG.PlayerLogin " +
            "WHERE PlayerLoginID = @Id", new { Id = players.PlayerLoginID });
            if (playerLogin == null)
            {
                return BadRequest();
            }
            try
            {
                Players updatedPlayers = connection.QuerySingle<Players>(
                "UPDATE RPG.Players SET [Name] = @[Name], Class = @Class, [Level] = @[Level], RegistrationDate = @RegistrationDate, LocationID = @LocationID, PlayerLoginID = @PlayerLoginID" +
                "WHERE PlayerId = @PlayerId", players);
                return Ok(updatedPlayers);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                return BadRequest();
            }
            
        }
        //Delete is a sensitive operation
        [HttpDelete("{id}")]
        public ActionResult DeletePlayer(int id)
        {
            if (id < 1)
            {
                return NotFound();
            }
            using SqlConnection connection = new SqlConnection(connectionString);
            int rowsAffected = connection.Execute("DELETE FROM RPG.Players WHERE PlayersID = @Id", new { Id = id });
            if(rowsAffected == 0)
            {
                return BadRequest();
            }
            return Ok();
        }
    }
}