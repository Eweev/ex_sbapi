defmodule Config do

   @config_req [:client_id,:client_secret,:website_url,:redirect_uri, :token_duration]

   def config do
    :ex_sbapi
    |> Application.get_env(ExSbapi)
    |> build_config_requirement
  end

  defp build_config_requirement(nil), do: raise "ExSbapi is not configured"
  defp build_config_requirement(config_map) do
     Enum.reduce(@config_req,%{},fn (val_req,acc) -> 

        acc = if(Keyword.has_key?(config_map, val_req)) do
          Map.put_new(acc, val_req, Keyword.get(config_map, val_req))
        else
          Map.put_new(acc, val_req, "")          
        end

    end)

  end

  defp compare_client_with_config_req(client,config_map) do
    {decision,valid_list,finalized_client_map} = Enum.reduce(@config_req,{true,[],%{}},fn (val_req,acc) -> 

        dec = elem(acc,0)
        list = elem(acc,1)
        final_map = elem(acc,2)


        {valid_client,final_map} = if(Map.has_key?(client, val_req)) do
          
          {valid,final_map} = case Map.get(client, val_req) do
            "" ->
              {false,final_map}
            client_value ->
              {true,Map.put_new(final_map, val_req, client_value)}
          end

        else
          {false,final_map}         
        end

        valid_config = case Map.get(config_map, val_req) do
          "" ->
            false
          _ ->
            true
        end

        acc = if(valid_client || valid_config) do
          map = if(Map.has_key?(final_map, val_req)) do
            final_map
          else
            Map.put_new(final_map, val_req, Map.get(config_map,val_req))
          end
          {dec,list,map}
        else
          {false,List.insert_at(list, -1, val_req),final_map}
        end

    end)
  end

  def check_client_params(client) do
     config_map = config
    {decision,valid_list,finalized_client_map} = compare_client_with_config_req(client,config_map)
    
    if(decision)do
      {:ok, finalized_client_map}
    else

      missing_message = Enum.reduce(valid_list,"",fn (atoms_required,acc) -> 
          acc <> " " <>atoms_required
      end)

        {:error,"Please check the following atoms: " <> missing_message}
    end
  end


end