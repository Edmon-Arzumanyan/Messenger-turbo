RSpec.shared_examples 'resourcable' do |resource_class, path_index, path_show|
  describe 'GET #index' do
    let!(:resource_1) { create(resource_class.name.underscore.to_sym, created_at: 5.days.ago, discarded_at: nil) }
    let!(:resource_2) { create(resource_class.name.underscore.to_sym, created_at: 3.days.ago, discarded_at: nil) }

    let!(:resource_3) do
      create(resource_class.name.underscore.to_sym, created_at: 1.day.ago, discarded_at: 1.days.ago)
    end

    let!(:resource_4) { create(resource_class.name.underscore.to_sym, created_at: 7.days.ago, discarded_at: nil) }

    it 'returns a successful response' do
      get send(path_index)

      expect(response).to have_http_status(:success)
    end

    context 'responding to different formats' do
      it 'responds with JSON format' do
        get send(path_index, format: :json)
        json_response = JSON.parse(response.body)

        array = [resource_3.id, resource_2.id, resource_1.id, resource_4.id]
        array.unshift(admin.id) if resource_class == User

        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(json_response).to be_an(Array)
        expect(json_response.map { |r| r['id'] }).to match_array(array)
      end

      it 'exports resources as CSV' do
        get send(path_index, format: :csv)

        content_disposition = response.headers['Content-Disposition']
        csv_response = CSV.parse(response.body, headers: true)

        array = [resource_3.id, resource_2.id, resource_1.id, resource_4.id]
        array.unshift(admin.id) if resource_class == User

        expect(content_disposition).not_to be_nil
        expect(content_disposition).to include("filename=\"#{resource_class}-#{Date.today}.csv\"")
        expect(csv_response.map { |r| r['ID'].to_i }).to match_array(array)
      end
    end

    context 'filters' do
      it 'filters by archive state' do
        get send(path_index), params: { archive_states: 'active' }

        array = [resource_2, resource_1, resource_4]
        array.unshift(admin) if resource_class == User

        expect(assigns(:resources)).to match_array(array)
      end

      it 'filters by archived state' do
        get send(path_index), params: { archive_states: 'archived' }
        expect(assigns(:resources)).to match_array([resource_3])
      end

      it 'filters by created_at date range' do
        get send(path_index), params: { created_from: 4.days.ago, created_to: 2.days.ago }

        expect(assigns(:resources)).to match_array([resource_2])
      end

      it 'filters by discarded_at date range' do
        get send(path_index), params: { archived_from: 3.day.ago, archived_to: 1.day.ago }

        expect(assigns(:resources)).to match_array([resource_3])
      end

      it 'sorts by created_at in ascending order' do
        get send(path_index), params: { sort_by: 'created_at', sort_direction: 'asc' }
        array = [resource_4, resource_1, resource_2, resource_3]
        array.push(admin) if resource_class == User

        expect(assigns(:resources)).to eq(array)
      end

      it 'sorts by created_at in descending order' do
        get send(path_index), params: { sort_by: 'created_at', sort_direction: 'desc' }

        array = [resource_3, resource_2, resource_1, resource_4]
        array.unshift(admin) if resource_class == User

        expect(assigns(:resources)).to eq(array)
      end
    end
  end

  describe 'GET #show' do
    it 'returns a successful response' do
      get send(path_show, resource)

      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #new' do
    it 'returns a successful response' do
      get send("new_#{path_show}")

      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new resource' do
        expect do
          post send(path_index), params: valid_params
        end.to change(resource_class, :count).by(1)

        expect(response).to redirect_to([:admin, assigns(:resource)])
      end
    end

    context 'with invalid params' do
      it 'renders the new template' do
        post send(path_index), params: { resource_class.to_s.underscore.to_sym => invalid_params }

        expect(response).to redirect_to send("new_#{path_show}")
      end
    end
  end

  describe 'GET #edit' do
    it 'returns a successful response' do
      get send("edit_#{path_show}", resource)

      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH #update' do
    context 'with valid params' do
      it 'updates the resource' do
        patch send(path_show, resource), params: valid_params

        expect(response).to redirect_to([:admin, resource])
      end
    end

    context 'with invalid params' do
      it 'renders the edit path' do
        patch send(path_show, resource), params: invalid_params

        expect(response).to redirect_to send("edit_#{path_show}")
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the resource' do
      resource

      expect do
        delete send(path_show, resource)
      end.to change(resource_class, :count).by(-1)

      expect(response).to redirect_to(send(path_index))
    end
  end

  describe 'POST #toggle_activation' do
    context 'when the resource is active' do
      it 'archives the resource' do
        expect do
          patch send("toggle_activation_#{path_show}", resource)
        end.to change { resource.reload.discarded? }.from(false).to(true)

        expect(flash[:notice]).to include("#{resource_class.model_name.human} is archived.")
        expect(response).to redirect_to(send(path_show, resource))
      end
    end

    context 'when the resource is archived' do
      before do
        resource.discard
      end

      it 'activates the resource' do
        expect do
          patch send("toggle_activation_#{path_show}", resource)
        end.to change { resource.reload.discarded? }.from(true).to(false)

        expect(flash[:notice]).to include("#{resource_class.model_name.human} is activated.")
        expect(response).to redirect_to(send(path_show, resource))
      end
    end
  end
end
