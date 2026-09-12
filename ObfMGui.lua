-- Services
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

-- 1. Optimasi Efek Pencahayaan & Atmosphere
local function optimizeLighting()
	-- Hapus efek Atmosphere dan Post-Processing lainnya (Blur, Bloom, SunRays, ColorCorrection)
	for _, effect in ipairs(Lighting:GetChildren()) do
		if effect:IsA("Atmosphere") 
			or effect:IsA("PostEffect") 
			or effect:IsA("Sky") then
			effect:Destroy()
		end
	end

	-- Riset properti Lighting ke mode rata (Flat/No Shadow)
	Lighting.GlobalShadows = false      -- Matikan kalkulasi bayangan global
	Lighting.Technology = Enum.Technology.Compatibility -- Pakai teknologi lighting paling ringan
	Lighting.EnvironmentSpecularScale = 0  -- Matikan pantulan lingkungan/mengkilap
	Lighting.EnvironmentDiffuseScale = 0   -- Matikan pencahayaan pantulan
	Lighting.FogEnd = 100000            -- Hilangkan efek kabut jauh
end

-- 2. Fungsi utama untuk optimasi part
local function optimizePart(part)
	if part:IsA("BasePart") then
		-- Simpan properti fisik asli
		local originalPhysics = part.CustomPhysicalProperties

		-- Ubah ke SmoothPlastic (polos) & hilangkan efek visual
		part.Material = Enum.Material.SmoothPlastic
		part.Reflectance = 0
		part.CastShadow = false

		-- Khusus MeshPart, hapus tekstur
		if part:IsA("MeshPart") then
			part.TextureID = ""
		end

		-- Kembalikan/pertahankan CustomPhysicalProperties
		part.CustomPhysicalProperties = originalPhysics
	end
end

-- Jalankan optimasi Lighting
optimizeLighting()

-- Optimasi objek yang baru ditambahkan ke Lighting (misal di-spawn lewat script lain)
Lighting.ChildAdded:Connect(function(child)
	if child:IsA("Atmosphere") or child:IsA("PostEffect") then
		task.defer(function()
			child:Destroy()
		end)
	end
end)

-- 3. Optimasi seluruh objek di Workspace
for _, descendant in ipairs(Workspace:GetDescendants()) do
	optimizePart(descendant)
end

-- Deteksi objek baru yang di-spawn di Workspace
Workspace.DescendantAdded:Connect(function(descendant)
	optimizePart(descendant)
end)
