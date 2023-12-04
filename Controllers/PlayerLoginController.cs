using Dapper;
using WebApi_project.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System.Data.SqlClient;

namespace WebApi_project.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PlayerLoginController : ControllerBase
    {
        string connectionString;
        public PlayerLoginController(IConfiguration configuration)
        {
            connectionString = configuration.GetConnectionString("DefaultConnection");
        }
        //get
        
        [HttpGet]
        public ActionResult<List<PlayerLogin>> GetAllPlayerLogin()
        {
            using SqlConnection connection = new SqlConnection(connectionString);
            List<PlayerLogin> playerLogin = connection.Query<PlayerLogin>("Select * from RPG.PlayerLogin").ToList();
            return Ok(playerLogin);
        }
        //get with an id
        [HttpGet("{id}")]
        public ActionResult<PlayerLogin> GetPlayerLogin(int id)
        {
            if(id < 1)
            {
                return BadRequest();
            }
            using SqlConnection connection = new SqlConnection(connectionString);
            PlayerLogin playerlogin = connection.QueryFirstOrDefault<PlayerLogin>("SELECT * FROM RPG.PlayerLogin WHERE PlayerLoginID = @Id", new {Id = id});
            if(playerlogin == null)
            {
                return NotFound();
            }
            return Ok(playerlogin);
        }
        //POST - Create
        //Put - Update
        //Delete - Delete
        [HttpPost]
        public ActionResult<PlayerLogin> CreatePlayerLogin(PlayerLogin playerLogin)
        {
            using SqlConnection connection = new SqlConnection(connectionString);
            
            try
            {
                //SCOPE_IDENTITY() this gets you the primary key of the newly created object
                PlayerLogin newPlayerLogin = connection.QuerySingle<PlayerLogin>(
                    "INSERT INTO RPG.PlayerLogin (UserName, Email, LoginDate) VALUES (@UserName, @Email, @LoginDate); " +
                    "SELECT * FROM RPG.PlayerLogin WHERE PlayerLoginID = SCOPE_IDENTITY();", playerLogin);
                return Ok(newPlayerLogin);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                return BadRequest();
            }
        }
        //PUT api/PlayerLogin/id
        [HttpPut("{id}")]
        public ActionResult<PlayerLogin> UpdatePlayerLogin(int id, PlayerLogin playerLogin)
        {
            if(id < 1)
            {
                return NotFound();
            }
            playerLogin.PlayerLoginID = id;
            using SqlConnection connection = new SqlConnection(connectionString);
            //Put - You have to send ALL of the information whether it changed or not
            int rowsAffected = connection.Execute("UPDATE RPG.PlayerLogin " +
                "SET UserName = @UserName, Email = @Email, LoginDate = @LoginDate " +
                "WHERE PlayerLoginID = @PlayerLoginID", playerLogin);
            if(rowsAffected == 0)
            {
                return BadRequest();
            }
            return Ok(playerLogin);
        }
        //Delete is a sensitive operation
        [HttpDelete("{id}")]
        public ActionResult DeletePlayerLogin(int id)
        {
            if (id < 1)
            {
                return NotFound();
            }
            using SqlConnection connection = new SqlConnection(connectionString);
            int rowsAffected = connection.Execute("DELETE FROM RPG.PlayerLogin WHERE PlayerLoginID = @Id", new { Id = id });
            if(rowsAffected == 0)
            {
                return BadRequest();
            }
            return Ok();
        }
    }
}